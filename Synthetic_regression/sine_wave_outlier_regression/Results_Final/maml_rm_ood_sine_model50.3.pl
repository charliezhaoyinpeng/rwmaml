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
qBX   1399356443872qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   1399356448192qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
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
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   1399356445600qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   1399356443392q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   1399356445888q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   1399356445312q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   1399356443392qX   1399356443872qX   1399356445312qX   1399356445600qX   1399356445888qX   1399356448192qe.(       
ƿql�����9�ъ��-��� �Yh��&��ڙ������PVٿf6̿�,T?#�2��zW?��E�����`�;����O��ۏ�)[ս$u;?V�x?��C��h�h�?ޏ>��25��r���3�8�
?hʿ�ː:T��>�ј������(       ���dQ��N�7>����84	�Į<�zS�>!®�<L��Ͼ�ǾD'?�H���%�T??�����i}A<�a
�qA?`�D�`���4�9�-�i�������Pؽ:�������f?E#�>i�N<R?�0�=�w�)�>2 �sp���	?       jqE�@       ~�y�&��>�,�<f� �0����;�>�e)<���uf<�ѝ�U<��%�<dD���B�>Ϧ�����(��>aS��>ƚ?�us��|��=U�=9�="0#=Ѐ�;�(ýkF4���9��>r�=@]f�AO�>��>��H?�c�;��>�Z۽��>=P��R��a6��3o���/�=V���S:?n��|�Ⱦ����u(Ͼ*��h�&�)���Q��-��>�?��_��E���A�9�>V��>^=�ɓ��hh����=>虾՞�?��Ӿ����z쾁s�?����&���6:�4��j�(��3�ڞ
�6#�=O&*�M
y�[A��}N��H+=��>�ۢ�,H���>�t6>�+�;M��=��Ѿ)�����!���bI>����z�=A��t코l�?�F���b�{��E�������ID=ϐ�=�,��u佹f�>���>��e>�%���Ļ��ܾCS������e��'�}�����i{�8��R:##�'�4�]��X�<@�r;��x=(�>�.�=��>��B���Ƽ�[���3ؽ˴�\����;���\O�@&=�[��P����W����ﯘ�U_U�`B���f�=G�0��Ͻv�4��{�1�����<�;����ǽॳ=���=�ώ��	��:ӽ$~���ʽ滼���<�_Ž�K¼�a�=>��=�(�Y���={�ͽ�u0��`>����P����[����c9��#����H*�|Lܽa�½\�8��<���{�\����=ZRC���i��r�/T����v=7i��Խ�=��>�mн'�H>��(����=��<�:I>en���Fɼ�Y��U��!�<�Ȏ���Q�ǅ��˜h��'>�4Խ	A =;!�����B�ǡ�/>p�<ާ=R����>�q>>q�>���5�G=��&>�S=�����E�����>���U�m>x~
=e�p����
FJ��O?I���;���*����>���=l���G=)C�=<��>��`=D�#�N��=�4?�ۏ>��=V�j?0q�����>���>e*��Ur��L"�O��;[�8?�==����>�蝾vJ�?�w�	��f�*��Z^>�)��M���[� ��QC��P@</f
=h��n��h�$�@ؾ��ӿ.��Wʿo
��%@>6��=؅�#1>h�d����>�H=�Ϙ޾��q��o|��y|?�:־�V��6�û�����0>�� ;}D���h��d�����ȾX�a��E�>��>H�J�窿�9��L�=0!���N���=�ƽ{Q=����8�7>^
d>�C����w�=�dB=�E����=D9�=��p��۽6N��KES��$F����5����(�	s���Ҿ����Sƽn�	�R�=����g�p>�\?>t��ʑ>̦f>�����S??fXI��>	�=�С��(�<�c6���{|=<�\�4W,�H!��fE���E�<pp��8�<��-�O=w�N�ҽ'd���+=$��<�8�5a���ؽ�`;;�_�=Tk0�	v\������=#�w=�-=1!�=v�̼�s��@�!���"ǽ�/|=��p�!�A�2�=m��8{&���&�Psx���j��<P�Z<� �lc	���>��r�=S>x��<�Ɉ� .��H���S����ښ�s�/�.��=X����6=NB�=ɩ>�X��Q���o=�)˽��\���M�Θm�(?�<�a3=,�.j��  ��`�ý����N���\� ��>�ѐ��)���<�*����>�>�VR>$�3��W-?���=��<>H[��Y۽P	>��K?t{m>���>&1>/�=�_�$�M>>x`:���=&���I=?��=�����K����<��P?�6>��?�b�q��I<>�?�*>]�� >̿�=�6|> +��?Q>��>�k�>9��=�=@��bм��?"�)>ǵ	�B.��@ؽ~�彠(1�"���
e�=N/>d>s���俜�l=���<�mP�����i���r���>��z>�MO>��>,��>}5������z5?�M�)]�>f٩�sF��R�>s\��W���$�ɿ��S�>�Ƈ<��<G�B�ȅ`���#>)�@=���:�6�x��=��п�a�=��T��c�=�FS>�\�$E��4�E��nۿ�V���ؾ�۾%׆��콙�V��k�e�����>[��>��F>}K�?M�P�Y�;���Z���_�t#�=�=*� �$����,���+>��;/>�P���ݒ<�?�>��=C	�����>�V��n?�궾�����Ρ���콣�?�t#���-���#>Z��=�d ;��3?q��=Ɠ�C%��X`?��v=��S���)�Z��>0���-��>w���~��VQ��eH=
4B>�)(� 44��4���>����>)܋�2,h��4>��J{-�/1�>�'����	1<��?���:����=↱������cb>�p�=}>}�7>�t!>7�3�����ɾ�7{?ђ������ھ�=�>ˀ=�۽>5?�>�|ؽYӖ>��.>bs��`�`� ڼH=�?�>�ٍ=ߛA��qؽ�rh>�D���j"��٥�M�-��I���?�՜�/�>���br�j�O�6�u���a�~i��&`�;<���>O�v=�׫��P���[>��,>�<+�J/ž�h�;L�)>�T2�'"�ؗT=`$E=e�M���$=H�����>c4���⇽��>B)�=Z5�=p�I<(�=v�̵"�Os�@�C�:�;�\�� @�7HK:=p���n������ć�8Yݽ���\/=_,�<�;�+6�:�}�3�h�O=>���Y�(����S�(MW�&��c�=1/?x��
�y>��п�΀>�ѽr����N�q���0��єC�Т>�M�֛޾�v�>!%�ɰV�2K=��aֿ�H�g�B��[?=���^\>��>�f�>��3>�����?Z��������d$��mٿ�/Q?��C?��h>S���T��>��1? bq=] 7�%�����F���d�#O���_>�Ǒ�"�)>��>ؒ?��˽���>�Ƭ���޾�!b�(3c>��T��=��?x�P��`L�}{�?i�>Mi��7������+
��B��������+=��7���$>�RR?�"P?� 
>����u.���=f�ٽʈ�� >Y=v=��2��P=��V�K%ǽ����p����B���3��u�:�C��׽�w�f]�����>ݽ�=�M������7�����A>Z���3�<�o�V�*�
�]�\t>�YP��н�Kh�#5�<t��Q͆��!ҽ��g�h@��o"��V�=jO������P-���
>��^��$�=@B��@���ݕ��W�<�(�=��=in �EU�۹��i���m� >4��< \�;��]��8�� C�<am��� ��'	�̭0=轠ļ�����h�BP��yS�^-�(�ͽ '�<|�۽��=s���t ����=�<���X6������׽M���=�`D<e~��Π�=���=�dD�(���s����
�Qw�G�X=']5����f׾=�D=��%��V�<tg2�m�p=�a��G����⮯= �E��ƽ,���e,�=2�D<b���RVN=��=����N�9�T�=��A>�׏��v�>�
G�/�Q����=D�ؾ֧�����*�1>.���	o��嫾(B��F�>���_�����6�$��9�p�޾Q�D�E�P�/|Z?���>t�>���=��a>lP"�¾�>����>��?�m$�%�)���b?[�> ;>>[�=�o�>��?�Y�>�+���]=>��� �>D�&���R�$�쿚������_�6��셿��>�����¾�Se���|���ꭆ>���v���q/�>��>��>>O *=ҽ=>��>��f��j�=�?�?�������U����'�K�?�Q�>��>���r�<�ʽ��=ώ��4��g��=������=	�1�#� >��>$Ύ=
���l"��5��f޼�5<�QQ=�b����ƽ�tF��ci���B=�;�g�콼��<c$ڽ�N:��Q�d���A�����8=瀧��if��PW<����"�D�6����%<�����=1S����a�4=~�ýqx���F�&A��I��=-p������v�=����=�p=�΢�^?���=i�j=>�����l�=3��;O!=��_��f�=���=�<.9
`�r�"�vb�<Z+=������<_Ǖ��D߽M|��|皽�r�=%Hq>dԪ>v&�>�+c���>�)">.���;�S� �'��D>��Ӿqʾ�y��l��r.?Ah^���D��Y�	Fi��eD��#<=FН��+m��C�>�4?Y&>���<9�a�j��;Z庾jQ>�MW�8�?>�|�>ӓ����t��h�?7p"?�l�><�=��� ѳ�[n�<I�1�]=2)ؾ��3>c��r_߽���ѻ�8�xץ����GS��>�Z�?ъ"�Ĩ࿋���'1�p��?�k����\� ą�iG��� 2�@;�>Y�=AF־ʤ��ϸ���/G�糡>��'? A�N�C���8��[�+�	������оϿ3=��Ի��k�Qȋ>�Y�u�ü'���<�E�/�ž�B+<w׋���>�*�_8D�S��,�:��=�K	<qc+��>4�Tb=Iŷ�]=��"�ͽ|i���o�R��>��>����`�>��+?�3>���<	sZ?"E&��T> �c<s ���>Zg�;�;�>H.��s�>ᇩ��:>�#o>~T�>����O@>�>7R���g>FD�=� ?U��>	�	?�W	?J�6����V��>�A&��އ���e=m{�=���8��̄��dy>3u�?�;��?���A�˹�>	��=�=f�>��S�)6���w����<뱮=Չ�=���>����<��	=�����l�����.�=����>�
��t���A �=�N�=�+����Rs��溅��r*�%(Ȼ����Ƿ,=������na�>���=IE���E�>0_>&�?EJN�|��>���0%<���z����W��U9P�κ>�����=��A/>�xK>bsD>8��>�u>���>?!��M��;r>w0O?�	��y'i�y�><nR�.�?ef(>,(��rc��콁��=QP�=��Ҿ���2��>�n�>g��=�K��%\����>ꓨ��������O½��V��y�<%���	�پn���x~}>L�A��Fl���A�Dr=S��I~�v�i���|��Y��vy=2�[����
��H�-�WL��ĩS��:�]L0?��\�%�o��F.�	C������'B��w�>�8���W>T�3?,�u>��o���g>�=����>3�	��϶>��r>��F>CN�����=���=ݥŽ&�>:F�>�\����0>j��>���>��<���>��<>�q���ӽ �>A�.��d�=VX��nF�M�X>���>�>��S>a3��w�>��>=�f��V8�<��>�e�����"?�>6W�?��>�>�C�<1/��Ҥ�{͖��*B��|��� �����p!|�w^˾����_�;�+�<�</����Ɂ�������&�>��$��w��ls��� ���?��|���~��V
�gN���Z�Q��=;s�����*O�{�0�2�vy�>�Y?!�n�s���\��+���q+l��B:>�_��
�*��0��>�Z��)�ſByοs�ʜ���=�����p���>� .��E�?�#��3�����>�/�?.��n��=�ľ=`��Ϩ�=�Y�=���V5��#��&.��%@����>D%?�=�~��@�<|�!>s�=�	ҽ��Z�\����M&�x�̼��ܽc��j"�+Uj�؎c��)��K 	=�����f=�7E�Oټˀ�=I�@�ٝϼ�k���<�ۂo�?�L��J;���=�CD�4��=��O�����*�2�����>��	�5�����<D&`�F\��Z�u�q�=ۖ"�0�'��N�]���0�=rҺ�4Ľ���=.E}=w2�=�p�4u�b/2<
X�<��9���=띜�-��<`���ɳ��e��~;��~��<u��=��:b+=�2~�;[�Խ*�=_|5�B"�=�O���
�o�=��>��h��=%*;}V��X�=���<gc��%����	�=�u���h"���2��=J*>B]�=���Qk�=/�H>�{�>�0�K��>���=`��?��<9#>��?.��\��>5
���Q\�W���=��j>?�?�%$���=���N
?;�:<F�.�[����F�>G���ީQ>=ş;(       +3�>��?4�k��n�<�0���=;2�>�߳>�>Z��=a1�=�e>��4?SV@i������r({>i���'?R� ������==�<����]����=�b=,9g��s?UX�>)�	?��>��Ͼ�(׾��?�(�>H�A?+�=ڇҼ>q��(       X� ���<6_K>�MG��!�]Y-�T��K��>��ܿ�Hj����K˿�¾�VB���.�ڸ2���I����=`}տ}풿�"&��R�=\�?.4
������н��T؞�ӊ�>粒<�b7��g����]>�	Ϳ%l�>NO�>+̾�,>K�7�~�=