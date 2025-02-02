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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2170595024016qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2170595025264qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2170595024112qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2170595023248q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2170595026608q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2170595023824q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2170595023248qX   2170595023824qX   2170595024016qX   2170595024112qX   2170595025264qX   2170595026608qe.(       �7��a#�Y���Ԕ�^.?ً>	 5�"�_�j�Q=��?�ŀ���o�ݜ~�Tb���&��B�>�=�B>
 &>\�"�H��)�L?-��m,a=^Y��zܓ�k��>�}�>|Ū�E�� 
�%-�)�0�]8��9�>�bɼdT�>���R�>ns}�       Dz׿(       }���H?.���#�5�H^۾Sԃ>��O?c�ֽ�k9�jw0?Nq5��ǾF��@���ɓq��oϽ�?��v���xנ=��<+&4��	-?rm�T2>�� ?U��`v�z�\�W��p��=�l�>20>Mۇ��c>
�
�;4>?�=W�2?Ԥ�>@      ���0��� =�1�ͽ�3��Dz=4'�=V� =@��<�#�d��< �!=��V���~��y=�X�=]Q=}M��U�<��:�k�ڼ�0��z)�cn�;9VW=7�2�G�WX�=��H�{��<�bq=c�X��+;�	+�7�񼊄���==�:���e�T�%<��A< �$<������!��W�<�JB��Ub=1�5�ó�=	����=�0�<S�X��ʻ=�R,=���h��鷽N���]��?M��5�a������<J�n=�5G=J"&�lN`=�T��ke��8�"�&��`�� ��<��[/��kYǽ��>�.�"�̿u+[>v�'�_�|/=l=�U��r�����r�D>@v���a��{�����=B!;@��F><�PC��|e�^�=�U&�Gj���>+�)�8�u<�\�cc�O��>��>%E��{��1���7>B����><���}>6:�U�彋�ӼI��;���h�=�7�(��<h�=p?/=Π,���~��=v����o=��Q=߂>�Q�����V������6�	����0�Af>�H�/B>���
JO<�Y=�X׽ј;���l�<� ��|�=Rb���2�=���Ǽu�eE��<5��'��q�=���>����c����T����H~V��}-���i�U̾��F�St>��<�$��k�ľ(4B��A��h~�(U>�����׾%��r����Ӽ��>�w?;?��]�R���� ?hX�<1�7�b�>Q��_^�>�`���d>u^U?�����{#�v�q>�N�Du"?�\��u��<G�=d�;�I]&>��{�x���r;P�e<�Q�=�č;uW��Ԣ���¼�I���O���y/=�s�;S�	��,ּO�8����>��Z=�#��Y��M+B>����X�=��<%�׹�<4���پ��8
�R���@�<��x�뢽O%����:�)<�l½Y���k�0����_r��٠����=�
̽p*=�'��I½�l��f�=�<8���?|���g���,�~�=�!������,�ؽ7����%�����=�~*�`�&��Z��!���.�=v�c��X�.���@�@���g3��ž�
�>[
�>#r��;�����暭=�v�����>  �����q�=��?�F����1�>d��= P�=��>�O}>fn��&>�n-<o/��&N���&���(�B�����=�:�f����>��>�,=7{��Ф?�:��qU��-�D��(������(����ZE��>�����:��=ōn��4����NX��
R�h����T��i���y�`����Xǽ��>N�ּO[�H�{��qK=6R:�o#=��!�i�x�0?��L�=��N�	�*�z(ؽ�=�Χ=$/���=�h�=s�>
��=���?9���xe�Ϩ]>\��-|>��3=h.���6����y?6�=����E(��I̽�_�=�;�>�TV>���=��)�<�	�(��=��<����:u�/?����v��
�?�����}�n��>���o��>p�*��Z�Xfx����\� >1�B�>��>��=D�	��e���?���A�>���>�M����=X/�>�l>�tü5��l�g=�J>��{����:- ���"=��_>=��ؼ����8�?u���Q룾YV2?���T�C�_�U��\p>���G �U*=Z!?Dw�>ͤ��p�D�s�=ƥ�h��<�Ϸ�Sϙ�H��;�D�$�j����>��3������ �XN�����N>=�'h=�!��gN�<�彊�=3
�=lv:�c!��>�95�O���U+�
\μ48=c8��{��<02)��1�=�(��s�<�M���_<�>�=\�V� ��=��d=��$>���<$U.=fc�>`DD?pL[��^�=1$��B	ܽ�(S�@4S;�r���g=<�k]>�]�zps?I����7������ >�W���O=�G=����0=��ˢ>��X=�=�>��j��QE�x�����e��i���B�>�p�=��>��>c*�>{&�����BX#>��&?��>@�t��9�=���n�=v?Eݗ�I#��Rb���<>�LܽV�|?(�Y<o��={��޼�����&=|,>�r��_����!'�Za�*ĺ�z{�>��v-!�v���s���OҾQ�1�Oʶ>�]@��)�b���Ed�	Y=��h��e�駲�#E$��1��F�Ϋ���׽�+s����K��=��?�)�[�=Z=��2�<�"R��x�<\�������S��W��;̬u���=e��Y��[���V$=��Ͻ��=Q#Q;;W�J�w�=zX��vA�D.I���=�Aоi����9Q<�̶>m�V� ��>�hs� '�|�4�Z��你�нREN>�Ѐ��U�?Kսoi�=�C��j�g��@���r�=�^�<�%�R�E����<�4����=V�>��p�B#��2 &��f=O+���SҾ���=��Ž[=�y<�=����G�X7=΀e=�p������^>|�v=��>i'o� 噿'7	>����ȿ�0ͽ�ݼhʷ�u�>m��>���=^�o>�CƽV&�=]�\��ݿ�����-?��Y��E���M��b%�>�1>F1�>|h�>�c?]&?�[��4=�>�k�=꬯��!�>��A>�rJ>�_�� ��Z�=V�=F���m�=�����9�>u柽X���;��=@�/�zs=��>�2��oP�/ְ>�����mo>�y���C���>��>�(��l@�>�K<��(�n��_#��u-�j5F=�d�?��>���[��˺�>����G�>��)>�P�>����*OF���>L�w=;���K)ڿ��
����>�=&Z��6�>�m�<�K ���?���VT!��?�>����>=\�,�s"���y���?��>�\&��x5�oV>�ʿ�S��y,ɿy��> �������= �Y����|�M=;�<�!�����Ƿ�U':���I=��Q�9m��[��˫=�,=�*>V
=���9��>I�=�l��[��<�~=Cy��ܤ=S6�=�߬�0H��ͯ=�z�S2�=(���<=��/^��Ƽ�m�0�����=�;�IŽ*��<��<���;����Z>߶P�QսS=~\4>vxw?\k?�"ϧ=!!K>{�m=ѩʽCt��	�=GT>����>lП>G9A�X�6?����D��=�lQ��%�=4�i<����>)ߧ��-T?�h��=5��r#�=m��>`�x�(� =�@_����=)w�<�¥���A?��=?"�Z��G�a?��%?ϝ�챍���9�8]D=�6�F���G� Z���,���?���ΰ(>����.<�>4w*?T �>UPľ{N�>*����(��~��Ǒ?��$?��O��d�� �Y? b�>�����>�@�>��=r�?ȕ�;B�>�j�<ಯ���ս�ҹ���,=kv��G+���I��S�=\���]�=N1�!K �УI�X�idA=�H��)3=�2!��=<�1=� c�Lf+=�����><@!�;]O��@�O���	v���=�r��(�	{0>��ན�!���R�2/�A� o�=1Y������� �$Q��?� t<�	��=��ٽ�X�ڀf�)2U�ބ�OI�;@N�=
�T=$)��7=�=O����ݽ�p?=�c�<P<�<=3e=�F��R�=%�缷{%=עn��Y�<��g�����:�=�P���q���D���$�]��:o'�� ����fA��d�ؽ��1���<}� >�μ��o=�~ib>q�=���T�n��3=x��
�⽮�'>�	< 73��k$�ee��z>e��<��C= Ӄ�ƙ��n�=#�-�?拾��������D�_�k=lo=�#��c^��̤��a1�4��=�1?�y�p><�=Ӎ=�+�=&�N?Rt.?
�=&�?>A	L���M�D���K=)i�K_�>�M>�����q?�w?��I>٪��?�L=�dl�/Q���-k>�;2�hMc>������s�gR	?R3�����<�X���@O�ܽ�g[��+�>M�]�A�i=�Sݾz�$? �T������Rp>8�����>�u=�~���v����=�?���T���ά�4n_� ,����,����>K�4>� n���I�2}����B�⾄�<?�����X�p�>�ǯ<r.���>�~x��-+?Ă���?#x�>'r����\>�W!?E�<�"�?<ѿ��X:���'>��ހ ?�=����=�޿��o?m>�I!��cx������=��z�tx^>��=�p�=J#��?!�in
����=���=dh���b�P��>O.>��?9y=%�=��)>���3.�ڭ��B�Cф>�%��:�L<΄�?-�>~��>��2�˘��I���HR=z�w�?d>��=�������?i��=nPx��?F,?�D���o@���>-:���`�>N̑��,�<L�>z�����fF;����<^��ڸB�Z��>t��Ɍ	���j�=�=il�������O<�	>@7;�S�<q��=�Z��U��޼�Ok<�H� �ҽ�����>���U���v����=L��i�F�0��T	b=P��$�=j=�=i�1��6����>3�����R=�$�=�T�+�,�!=�
���г���<W<���&�=F���zm`�`v�	>w��$�=���,������<!��rἑs���l �`�;��M�=�
<��Y=���=�x���p(������<r��=&�ٽ֭���ս����Ȃ>�cX���$���#�;�=Q�%hڻ-W|��E��oȾ���Z��Ѣ��C�>�>�U}>��>�]m>c�=:K����>A�>��ý0�ӿ��>�ˆ>&A=v��@�=�s��i�=��[�
����\�7��>�nO=�2��3-���N=g������=��>�#E> r�<������r��-$�s�}>��j�_V �ete<�޽a���xO�����l��=�mY=�� �&}�=����'�J��=k�=$q�� ������k��>�K�9�5��_�=�<��{���J��"ѽP�_=c��=����R}�.0g�(㭼Aޅ�@7;ϳ"�O)����溾�Y9�?��5\|�����H�o�����=�����>��=j�0�>��=i�%�x���~���+���v{�>�l9�/�>VE����3>��=k�F>2�?�����B>$U>m�y=U��=uA.�Tk\=,Р��=�Yx=SBt��3���>��&��%>>�Z��{n>>r��}?GYO="�c�3*\?��=�v9>-�}�AF%>'Й�S�ֽw[? ��<Ã�#U?.�F��O_�C�=���>Z�>�U>:�پTj�?�7�"S������l�=�k?�_����=Hd^��7��7��ZS� b�<J��і���#R�`[���9��>�==%ĿU��=��P����� �����g�A�=7)=�󥼅�=�?你�̻���=�!>��a��� =Gh���=˓��GN=Sɩ�A���,>�}	$=W�2�� �����:.%��=<v׻��N���=_�M��O>�D�=�*>w����-�Rc�=>:=N12<����H�hP�>�C�>#�=q9�=$~�>0��>��8��:�>��Q��h�oC���o��y>��u���AR���>�����!�(`�������>���<a	v>|9�>(c2>��R>�mC=ь�Ӌ�>@@`=4�>�����H��:¾��J��g�9������v>HK����&�m��x �A��=6B�k'�3�޾�*Z<^b8;��=���=t�����<9��<�* <��;���A>e��=��>��=4 >��N=\�<�Jp�⭖� �ʽ���<
� ���j=1���`�)�ur����;u�%�� 	����=�<�n�=%b�>���1?�W ��J����(�� �����h ӽ�������TD���?�R�I�41�=�ʿ^��D�s�a�,H��W��!�D��Eo=�����Ϙ�*��?��[>��=|�?R��=�����c���ƿ��e�\=S�'��� ?�c��?��
��=��A�S�/<�4�=����_�>�6�(���9=�,U��>�^��e��X��>���^3�[v$>b�=���=bf>E>�.���N>#A�۩��&jQ<�Yi��{�پ��=��ݬ�)��=�lV>����<`u�rD׾���?ήٽt�O�(       ؇�>�4q�	IZ>�=�;,������b�5����=��1���ҿ�#��'���י>�
r�3;#��~P>No��y)����>�<~>�3>�W(�XJ���1Ծ��8r�%} ?.�>$��>F��>N�F��N$��d�<� ��z>�s[>�Ҏ=c��>��(~�(       ��=�hʼ��X?�{<Z84?8�~�_߈<�Y�>���>�����c��7�>ѱ�>�9�<�w>���?ۙ��ܒ�>D$k=��?��a�-��=|ˑ;T6�=��>j�?��S����>d$��������>��Q=���>�7���%5>��|�v@>J��?��>