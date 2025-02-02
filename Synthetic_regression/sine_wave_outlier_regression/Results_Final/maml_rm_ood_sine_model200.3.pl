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
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_rm_ood_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_rm_ood_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
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
qBX   2327161723408qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2327161721488qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2327161723504qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2327161724560q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2327161723888q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2327161724656q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2327161721488qX   2327161723408qX   2327161723504qX   2327161723888qX   2327161724560qX   2327161724656qe.(       Z���sֿ��_�����'��{>�9]c=�2��t޿Q���/�>U�ٽR��������>�F�������=	4���0�Q�9�:RͿ�vX��ۭ= �������ҙ,?m-ȾG��w��<�5�O�><A����>(þ��sA�	H/��l?1L���3��(       ��9?�?��	?�^?UjA�4�>���=�%�>�+2?|�;>�ҋ��q�>��>j?(�=h,L���h����=��澽�>1�S��Z?�(����^=��%��7?�N�=��̾�?8M����F?yД���?��D�{�o��>#�3��a���>B��>@      �X���^
?u�'�k+��)�>�/�������Q�Lg���;��?XF���F��������=Jj>S��>v�:�Hk�>��ɽ�t�>n/������qw@�A���8����>�ٖ>�L�+A�y$)���>�b#�z�྆�{?��+��&۾88u�YRƾf	m����1u�>���;�:= ��>3`�<���[�<�����d6����>�5ٽ��;}>>�r��ݬ>\A>A�	=��L>�+���@1>'e�=n9ݽnUm?�z�>Ԫ���ѿ���>��>�[�=�!����?�;���¾���>0�.��{>D���ZR�<;�<i/��#��s*�=&�I:ʿ���=GX>!>G����|Z>S�X���m>w�L=�ӿ�����k�+	g�<�>^Q����H=A�	>���l	>�X=�T������?�����)��� >�d������`=������H>y�j�n,?�>ڃ�.Wu�Coh��w�fe�{=�4>�T?/�M>L�ݾya9>����1a>I�>���I/@?��:��xP�;��=m[�0�������g��[���1U=\6>J�ZIF>�>������Z���o�Ǆ������$y�iي����=�x>�W�?~�p���%�]>�=��@=U���<�׽Ķ����!Y�����@d>(�=�ȽrѦ;y�@�ObA>�C�<�����=I�{=Ԓ����]�>�)�@\2����="P�>�yA=�e��9���j	������*>�罈�5�"��yD�>���C?�����rO=�6ۼ��)>R��"��=���}����� �?�~��0>�}0:>i4�k��?SxO�������N¾�X�?A�F���B����f���=�~'>��3=7V�>��M��'�>u9p�BX���S�=�6��;7�@��?���<XG5?F�@�rG��'l���3�P��~�>m��;���=�p� �>���<mu�=:?=�l=OuT���W������$�<I���`)=b鄽&DT���3��ͽ�E>_S�´�=h)�<e��1f����=�D����=�t<��*=C)��B����ڽw�b��^�=I�x=� >�m�0��q�g<28>aJ>ד	���:>�>��Ľ��<�?~ӽN�<ԭ�+߅>�B��ҵ�B�n>�d�>��<M9Z<t���鼺��/��*�=��[����U�?V >9sr=9?������%ώ�~��=r�}=<a>ȃ˽���������27پ}gz�'��N�=_r���f�=���L4!��j>�á=�TK��j�Πd�"C�����U�}��q�<�{ؼ�9�ގ9�С���	ν�)0�&�	���=���:9?>B�L=$��f��=��=Ȯ��=Vl�=�����r>�#��=�Y�=��񻿧�<Es�r�����u��=g���p�۾�U\=�U�
���G>�$龵�M>��>Aҥ=��	�֝�>j0�>����O�{?�8��~Z�;x�=bԾ��S�^��7�����E��� ?K���'�@ῷ|���q�=|�z?kA���=�O
��:?]�
��E�=|�)��5N����=���>B�v�=%���(���޽�0��ÏK�Rj����C�9�R��F'��&?C��{����	����n���~<z^;�
�|��c��̾���W2�|ɖ�G�,�Di+���K?7�[��g������BѾ&I?��m�u���Q����~3 �h��mq3�<|	��?��H�{�.g���믿������R���$���@�O;Ž��?��7_�lu��pھ�+�M�x�����vc�>v%�/�;�����@`��|��`�o��j��lþ�D�?�ɾ�lþ�Yx�������䑾��һg_D���*�4�K���d?��g�:��P�彣_��m@��D��=(r�扃����<vǚ= ��\=�=7�$�C� ��E�x���h�����2P.�J݌��u[����늽���@;�Ђ�<l>=߽����]�<�-{���t�lU<=�tD� `��x�̽#�g���`F�jc�����J��=B0<ĸ����;��½��=}V����4]� �q��=��ZĿ=�[��V��א���h�Z;�=Fz�=:�P4׽�d"��� ��e���p<�4����="r��f�a�������P�=(@ڽs���=޽t���厼��9���>T���>w��_dϽ×���_1�[�>��N�������NZ�	(�Z�;���g�����R�t����pk�����������q\w�(Y�=r���f>�k���]>G�C��+Ŀ&��Od<?�S0>�7�춅>p����>�� �>v�����a��s��u[�?p���o?�Է侵�-=�-�α�]�ֽ
�N>���?�0=�Ծ�~�>Q�?[y?��>`h�����`���� >`pH��|�<�ɾ�m1>��G�6�=��?�K!�]Sؾ��f;=ڑ>[�(��\>�6�!��>��8�o��=��?ZoW>�)��յ����)�Kv�����>��?CW���%5?��A??�"?W,%?m����>S""���>���><��5����)?�=k��>ڄ�>	��>�[���f���{�P��=T�<��s��'���X�>�z9?��?�����f�>��׾��t��O	?��>/>��%?��Ͼ���>��	f���`����>���<{Q?I.ӽ�=���;yϼ}4���L����F�$P�p��;O�4���?>t�׽/�>Y!�o�->�1>a.��c�3>�=��4?p% �jm�)Wپ�=s܉���`��Ծ�(�K��	�����I?���;x	�y�={������<�&ɽtb½I����а����޾6������	�=v�����Ĩ�=�����z��K�=�r��6I��
���<�.O�Љ���� �@�=S��>B�ȽԚ��R����`��X���4��п5�P���#�M7޽)
?Y���� �Q�%�[�&�\���w+���Y����>�l�>��?b?�S�>�?�l
?�y�>����H?�D׾�UE>n ˾�&7=A@z��L>Ӥ����߽,6�?�,�k�
�[H���5q>>6>T@G?��پ�"?:>!����>�?�>��>O$��&��:8	��n5�?������zg>�r;=(�u<�͂=�<��%c�<k��>]��=���>��㽗�o�6�}���_=�>�ރ�)�Ⱦ��c�+>&m�[>� ����%>��y�~�E>�޿�w���Q��N|ݽ6C�=���?Y�2>y��<_����(���{����<R\?+��B+�>{??Q\�`]K?�^>DB����$>�
{��>`q���J>��>�6��(�#�cV?.	>�X>��>P!�>�é=�'�<���= ?�D���e�>��?�<�>��>�qH�M鶿�Vu��s�>zj�h@�����>�뇿l�?�>e�����>)���� i>���=.��L�@>ܶK��.W=|2?���=��<E{�=��Z>�@���7�>��<�@+��[���轩:�=�P�����"ή=r)4?,��=��>��пV�=�~a>�E� �?���?�w>8}��I�w��J>q��ѧۿ,��=PN�>S�<>�YҼ1�ýp�@�?�;>2��]/�=�h���_>K`=�����U8�V�1�M0n�x��>m�>����L���u@�ڋO�IM�=�H�=-!�>�-5�6�]>��ѿ��j>�)>���=4�X�����;ؗ�-�>=��>�R�井��L ��_�=\��>U�Ⱦ:QC>%��>9w_�-ʽw��>���?CM?�����ύ>D�޽K��>C��>�Ѽ��?a��r�>9���F)?�>0�i>?m=��T>KF>u�1>��1�L=�D����6>��?���>�[��џ�!��>U���X޾)�>�Y��#Z�K�>��k�i٠�a" �g�����GFϽ�>E��I�%�=)V���h��`ƽH�ʽ�@ν����5�"w�=Rt�=��=�}d��"�Uy><�����;�	�@�;�=pj���9<.̆=�H
�h�ƽ]�=�V�=�"ͽ�������&��=�d�=�D=Y���Lq���۽��~�
�\��������Z�e�_f>�ӻ��E�k6��oq;���>;J�����Z���==)�o�fx�`�+�>��C>b= �ZG�=B��=T(O��)ƽ��J�M��ܼP�[�[�`���d���q�<؀ =�p�9��x�U=XEϼz�3�ٕ�>���赾��>���E������|��=�xW>��%�(o=l�I��c?��K>��yԥ�:b�=_����G�{4�୛<���?,�u>L�v�ा�D<o�ѽ<��< ��^=<n&<�g�� ��Y��=����ǿM�J�p<�s�ھm�|��88�킾Ӡ����^H��uҧ��k��[�h�N�6w���Q���D�Y�O�֟V��cT���ƽ����7���x]=ȟ������h�<9���kg�����?�쵽�?��VͼRj�lƦ��g��j�>V����j��^��p��?j`=;I�оl-߽�� �=ɉ޽�w�m�r��P��@iʽ(#F=
ټE�|���G���=�t~����<,lF��c��h�ս�IA���&�4ký�n�G�m�c����
.=�t���{���m�i7��>�^�������I�E]
�v _��C�=]������䝀=M�>���<{
.>|51���d�fƅ��#p?T���ρ>�>���L0>n�۾�����6�<�Y�Jo�>N���ҳ�5��>!D=�Ϧ>q�>�6>Rvֿ�7P�N�>G9?�s�>���< ������>AZI>��<�����M�x�����Ŀ5`>?�,�K�޾iߥ=�����lҽ �6�8�;���ʽ�f��ɚ�;6p=�J��Ȋl�Q	=m6ӽF�@4?��<k�q=�$��K��!���w7��H�p�J<@U�>Í
=�AA��Q���'�T�=�ĩ�KM|�7�r?�[R=��!�'���3�o=�e{��
��`}=-Ǒ>'�ҽ��m;޶����T�������ս:ﱿ����� ������>*d��7;�o	���B�Ʋ�>L���wſ��>ӡ�����=����]S��
P�Ъ���� ?d��=��H��]q�)\�a_>S�{����<H�����o����y�)����i���j>���=�V>�z->QIH>Zu=%����F�<�>& �@?�>`6���C+��9���?[��=>�B��鏾}�|�`��_��Ni�=j������>�R?�=9W��1���&>�.�Ј9>B%�>�>1>��?D��q?�Yc��׽���=YE"?�B��Z�W��r�<0B��U6�*$`={G�=n=�C*�i>�Ͷ��k���.�='�)���ƽ�N�>�G �����и�>!��=��z>�`�=������w��;J=��j�f\�>s|�>��?)��!J����Y>��?�x�����������=�q3>����"Y�P��>t�n�c���n�>ܐ�4󻿷o����P�Pc�4�E�/���w�O�m�����>��=
�=�T?}��=�f<6m���9�z��=��W��L>������m�a����5�}���ӲG����9���ya��o��!����?��U�4YU�N(I�dI���=��l��7>-":>�B��`�>Q����=�5��b2=Ԩ4>���!_?Ȕ2�`�=��5)>> #<���K^E<ȋ��B��=�>q> �;�ɏ�m/<��ń=]�R>	R�=���?�uZ>`��D{+�>d+m=>h�=��E>���(�=��p5y�-b���O���Z��ߖ���s<�컽�}{>�&?6�彯9z�iE�=,� �i>��N?d>	�q� ��>όa����.:���J	�H��<G�?Z��>Ғ�}U=�\=���>.`=?��=)�I���>���lȎ��iӽ�����M��H
�Z@�=ȟI��z��,O���h��N=����]X=�P���-��-�T)��9^�
�Z>ڕ:�F(o>��_>�q5=�q>׮1>�����Je���=��]?��>� >��?>վ j�R�=�X���i��1;�U߿:��?E->]>Ⱦx$~�+2���Yt��-/��ց=T��Y��=a�ڻQ !�;��=�����㼼���: ��Y���tӽ���r�����U�A��w��^�ɽ ���,>L4=����(T�2"��P9�^6߽u2�~ϖ��Y�6���@�q�!��;f�=��=�=nt��(       6
?	~?��!?b�?��̽"%�>��ͺmn�>�Kϻ~޷�OV?@N?J�=�7'��^S?x���6t�=T�������!7�Ԗ[>�ּ���?
�C>�9�>�H�<�����o ?83?�?�F���>�ؾ�8p>Y�/?��m��L&����IK�(       �2�7��1N���N�IL���%���<W�i�񯜽�8?�C�>��O:OB��ȽG� >�W?��>��b���S�?�)~�cܾ�����kM�^5L�3�Ż%�d=�������;�JR�MP�j�'�1?�7����I7�,�N?Yc?N�־F��=       ��~�