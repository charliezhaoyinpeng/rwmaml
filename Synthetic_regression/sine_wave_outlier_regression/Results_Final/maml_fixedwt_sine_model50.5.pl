��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_fixed_weight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_fixed_weight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   1551892094896qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1551892095280qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1551892096144qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1551892094800q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1551892095184q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1551892095664q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1551892094800qX   1551892094896qX   1551892095184qX   1551892095280qX   1551892095664qX   1551892096144qe.(       �綿vꋽ�#�=��[�=�m���V?��t�>~:�%W,�ȫ(�I$c?(:�Dξ��>CA���{>��{���>q"�>B�����=���%�EZ6�����ܫ�a�վ\�>19�SA������־�q~��7�=Mk�nlʾ3_�>��?(       *�	�;?�>�?7V
���2�Pb>!C�>�g���45?0r��CU>/e�=t,?�UN>���=_�<2�c����>���GZ"?�� >�	�Tr;<�m=Ȧ�>me���Ù=l �>���=�8�>~*���>�J��]>��9��Oz�p=�:]�<���P#ɽ(       �,?�e��X?��p=��'?q���D<��[l���j?"��>J��=��>�sk?y�C=J�2<V�˾��ʼ9SM�@�>���U?1�н	P�>�N=��?�а�su�!�>���ez?��J=at�̷��w��h�c��O�>�4�;s���߭�?��(       z!=�~|�>^�G��(
F�"rs��hO��G���'����lǝ�G�A=�x��ޑ��D=�~h�=�A?Hоm��>ϕ���@w��ް��R��e3�>��!�3z�=$�^=o�f�R#>;~�Ը+���������$�>2� ?����]��>����b�=`RC�        C-�@      U�>Y� >�g=�U���>�챽ri>v�=���<
 �=��<�::��«>�w�=�$)=n��>�O>�J=E����= y�<���>he�<=A���)>�a�>)]�<lpP>�ي=��d>G�>Y����G���p=�'¿%}-?��`?
�>��=7���[.o���<�p�k�p��7�<rC0���/>�|���1�	�>0�彜4,�W�=��7���>d�o��|h�*��=-�:?�2H>�Q �mK��M��`�>u�V>)�k?]	�=���=�8�=�g񼞾E���>ک���?]X�?�l���߾�؂��")��F���P/�j뇾1g�+]��x&L�����S�M�I� U�:��u>{8?�L�tI>LF>��������g'>%�ǿ����P�K	_��3=�RK�T�p��[q�G��=�0ý,�=4�R=4۽[�o?Qi��L�>�ʨ��/�#n�>��(��X�<6����<�M�=���6����t�
�ƽm >'*��\�=.-�=u����|>��ý�)� ���7��V�<�>4*��o�<"��=���=ֲ'��n��!��q�Jl_�1Z>�7��̂=�B���.F���<�Y��Ei��v�+���7�Pk���?�8�վ(*��[����p���>�H��}Y�XK_����-��b�⿐-<�𼶽�1��ިk�Ù>������=@^¿��=���5�H�l�O>^��tv�U-B��4��靽`G��hTr=N];����6�{Y�>F[!�h���ƿ1u�=�d > [�:�e��?���=��=[�<Y�O�Lߟ=���� A�<�&�;$=��$��/����=m=���e����ħ�e�}=n�f��n=P�]��<���<|�e�E����K<41=��L����2$�������ؽ�Lą��b���9�L��r7��������U���̀�Q���a�	?��=��콾���꾿�>���>|�>fX�Q�>S�>�?���>�%�>��y��kk�H=�=�a���?i>�M���>赒��}�=�W��b��>���>	�>�'�p�hD.���ϿhE�>i�?!ح���>r��a.>�ؼ�2`= ʼ$3�=å��. �Vu�=D���>Y�=�>B=�3պ_X&=t�j�I��,��C	O��u�e����L<F>7���"���=�0��}J�=��*�&��=*�=[�h���%�&���&�<#�=/#9=&ǽ+�������s�뭽pؘ<	:�G��=b��>�7���<!�ٽ?w4�'B?[sT=|��Ͼ_<3��w>� �S��Ǫ�L����Ν?��U��2�=K;��R/�R�f?ϴ���>?dڅ;[9�O7�<8�ƾG��=¯h�ze�v��=�,�?�uO�Ӧ���r��y�P���뽸��`Y�<iQ���L>��ᾌo�Q(�ߏ�����k���?���=J��2@�G���u?;b+�	:
>��N��)>�1>B�޽�l��Yz�1(>�?�>	�H��=h����M�=�m��;	 ���P��E!��d��-�����⾦��=ƥ���4�v�	���P���\��/�=\�L��^�:�K�2��=�]��0��,�<��匾ݐ��k���+�MP�\>�=�u���������:����Oۼ=�X=��%= A��<���V�n�S
�<���_]h>� ���V��9��2�j���K�M�s��Z�=O?���O�P����.ѽ<�����G�U4�<������5����F�>`=S�2��
��I�뾏�E;mE��@(>`)u=)�O�P���1�M�t�<��>�J�>Ve���nk>#�;����u��em�#��>W�=����1��>&��F��F��=@&7��F�\�
��8�������q<P������-�`�;8g��Xǽ%����l��d�=
� �eㅾhE׾@��>�����%�� ����P@>��?�2p���>�1?��e�*?��Ⱦ�⫾d���b���<?��A?��B����=�,k�T�w�`��=�/*�\��;!TR;z��4�_�P���%�o��d�=�靺����-�@���������y�=$r�j�I6`�O��6��<�	�;������g�E=�����=��@�&��>+��*��7#��'�H%�<*9���Z��k=�J���=s��=(`��G���X=	�I��ǭ�J�����ʽ�"E���<��Ѽ�b_�N�L��Cǽ;s=��<>�π��q���m*
>���!�����6�"B�=y����d�$%*��������D�7T��o��5����7�$�����ս�w����������>В|�����J��m�?�R��x��=���0�(���=��>���������>�Qp<�&!��=~:�>)������>��*>QK>���=��>m�}�D�>Ę0=ɘ>ϖ�>�
�>wq��"���c�:�����b궾7�f?���m>�u�=�[�=�D��
���ϼP���~�=�"G�FX�@�T�W>����Q���2���e���νpdt�tc��\�>�Z'�:�.����;����<����`L�p'=j=���lA��7���@����6=�.G�d�ҽ��u���	�D��1	-�����c�d�d=x�>���=�HJ�:Z���K�����;���$V<�b�j����=;���N� ?Q.l�ԅ˾R{�=�*[�Q��>E־N�|��f-�1��� �Zˌ�}*���a��=F�P�f��y[���M�`s��&5<��a�t�����?1l�-� ��!������:<�o|���u>��J=����&-��(�=���=#�G�m��>�ᵽ�,='.����>,e�=L����?\r!�oyn>j����> ?C��_��|r�=o���/">��>�Ԑ=~�z>ŷ��8N>�����'+��ֽ�Щ=�X�B�.��N�>LO� M���>�a>_����q<�K7Ծ'de���=���a�<R��(G��qp�D�>y���&�
���<�?���>�m����?�G��+i>�Ŋ=J��צ
?�泾*������yˠ��b����3τ��9����p���׿I?#'�"6� ����*�xd2=�UR��<���
�&h6�JU�ڝ�=�P�����4<!�6��=�X>�U�>�Cw��{>6mO=�FͿ����=�h�!c�>3Ji���=q�⾋>{��>M���z,>f�=r3�E��>��*>��{+���=�)/?&�r=H����G=5�Z�N�4�$$,�e��h�7�����隽�R� �@<����p�"����=&�.����m����R�'��*���4����J�e�0[��vo�3���Y!���=��X��A �=Y�=^�G��u=^<�����=�.�S�<�m�=,7���%9Ώ���;�;��G<���=Ifl��?��x����Ę��� >��=��%�0>�./�=�M>J�?�"$���t>��=WO�� ���)�=���W#-�1��MR�y.>n+�� D������U�=oZʽ�NN>+�>@s�N%�><�o��>��vܾ�Gֻ?	L�пw�?���B����^�b�9�m�ؽ� >�;=��;�{�����=*�=��R�_>sʋ��7�=@�	=�^���hօ<޳�췭��*ҼQ�Xq�<�V�<-����ǽq���< ֘<�
> 0 <E��� �~:�c��v�N��Z���>��	E>v�Ⱦ��2>Y`i�G���ؾֈ�=���>�ݖ�{	�:�,>�?*>"O�>\�>�8=�6>���C\>�ZH>h�ĿrT>r]�=�>���fn=A����=������=�>��>�ܷ=�P���>�x;�R������B��c~?����S�4@��%�=�Ì�;RA����<!���6��T��՗>B&"�`���~��Z��;оa5-�Ć}=;ژ?��B���P�?��Ӿ���3<p>�BE���2?Z��ޘ6>���Ǻ�[���0��a��Z�>ή���7w>���>u$Y>v���Uy> 0��'K��>6>��̈́��)q	�F�7�z��==7����=m+��C�=|�6�u����/�C=$'�)���=lf�=� += ����2>Fk��;W="�O<F������=<���=����W��=�MF��8���>�ԃ��c�;.р=��&�Bd���c�P:^��9�>1},���\=�R�>��[>�M��M����=P����>����PJ���D=������B���(?e�G>zJ�{������1<F��>�����ڥ�P��=� ���Ŭ�{A��"�߿��=�9�=`��;�|�>��؍`�Y�>2����9+?AV#>0�y<K�>���5�O��.6<�Z�2L5�� �=ă���]-�ڷ�=]���#��O;x���0=ʻ��a=a�����>�9?6���؛���r���E>js?�u�="�	? ��>j�}=c>�n,>Kď���=�p�<��>xZ���%����?����i�Z�r��vS�C�Ծ(Ք����
0����=�I��	����g�b4�= �0��(�=D�������=��C���>1�"���jd�Rp�=��w�e�E�j�9�B���`<�l���������1��w�=;�-%��ʸ����>`�e��귿�Ŀ|e�> �T;���j�{��j4�����R�h��E�����HnJ=M<>�z�e�A�يb�c�o�z�7��%�=�{=ݽ��j�ܽ�pC�o��J��=$C���5�����~��=1ߌ�
@��X�_��B�E��^�k����=�\��r�H���
�/̼��Ϟ���l�Zo�=���='b!����./
>������+����4g�=1�6�;�=�D��26��B��h�G���~���q?����)��%>j��@%��o-�-_�>m{�>	FT�d���վ��7ɮ�%�f����(V����=	F�?�X?�� =C�t�>�'�����D���Ѿ;�{̷��G�=�R=�K>�P�����.�<��;u���M�=�<���$�ǿ�_�<�=���>*�s�M�<`�=t�����[>�1}=Om�?����������3v;�4�
��ʢ�%�>A�?���>�,�=rÂ>�O >��<�[�"���}"��ݽ;��>Lw�=l{}>3��������
/�F����D��Y���>y�=`����=��>�%-���h�4e�����<>&A�E�G��]]?��k=�v>z�����l��>5[�<1l��K�?�uI?zWD>-t4���<gil>���<���:�D ��N��B�;H����y���9;@��<�d=R~������Ѵ<tA&�R&[��<T�g��<½��S���f�h���&8�=�I=J����@���Q���R<��<*��TM�9A>�dm�7%=dk,=��f�r,��*�F���q� �r�w���H�<ĢR�"�>�o=���`Ҿ8!�<4���Ri����<m!�:v�=�t>0�ڽ��<*_����С8�}�L�+="W����a���R��Ɖ�ʴ?�_��>���,>�������m�A�Q+�=�Y?��Ӿ$��
:?�(���dc����W_�<�s��ݎ���-A�+ɽ]���X��� }��`�dB�G|���<�Q���A� �S<�h���c��.'��do;v�='��>?�Mx��,����H������2���5�Yl�5m��5�:�x�e����=e3>1:�=PZ$> k?�����2�����@���|˂��0�0�>��ƽ]>깋���5���=�O罏4�ci��)��c����W �^Դ���>�?_�r�N�=O6��Fd%�	w>a�G�j�?6X��^�<�Խ�
��6��>T}��_D�=ܤ>^ҡ>����0>s���1��>p���{i��s"��D�8�4�[���h���3\�j	���f8��,i��ÿ��x����c�]��B/�m����=?Zv<���؈��o���@۾�l���D��](|��&���`�C k�<j		�"ޑ��� �}�q�׊�=�' >�������������@C>nX�=>�C>9.N����=D��f�Z> E�;r�-��뀿��;�ؽlS���<���[�|�[x��rqr�!r?L(u��@��Р=� ���y����U���ƾ^�~�t�
���ὺv�<˔r��ӡ>��ܽ(9f� 0��F��m����Y;�������<>���